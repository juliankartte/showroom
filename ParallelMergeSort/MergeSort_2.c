/*
 *  MPI Implementation of the Merge Sort Algorithm - approach 2
 *
 *  by Julian Kartte
 */

#include <stdio.h>
#include <mpi.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>

#define DEBUG 0

void Merge(int* left_array, int* right_array, int start_index, int middle_index, int end_index) {
    /*
     * In this function two arrays are built and sorted together.
     *
     * int* left_array      pointer to the array which is to be sorted
     * int* right_array     pointer to the help array
     * int start_index      start index of the array
     * int middle_index     middle index of the array
     * int end_index        end index of the array
     * int left_index,      help variables
     *  right_index, i
     */

    int left_index, right_index, index, i;

    left_index = start_index;
    index = start_index;
    right_index = middle_index + 1;

    // sort the elements in comparison of two elements in the left array
    while ((left_index <= middle_index) && (right_index <= end_index)) {
        if (left_array[left_index] <= left_array[right_index]) {
            right_array[index++] = left_array[left_index++];
        }
        else {
            right_array[index++] = left_array[right_index++];
        }
    }

    // if elements are left, add in array right_array
    if (left_index <= middle_index) {
        for (i = left_index; i <= middle_index; i++) {
            right_array[index++] = left_array[i];
        }
    }
    if (right_index <= end_index) {
        for (i = right_index; i <= end_index; i++) {
            right_array[index++] = left_array[i];
        }
    }

    // copy the elements from the array right_array to left_array
    for (i = start_index; i <= end_index; i++) {
        left_array[i] = right_array[i];
    }
}

void Merge_Sort(int* arra, int* arrb, int start, int end) {
    /*
     * Start the Merge Sort Algorithm with dividing the array in two arrays.
     *  Recursively repeat until smallest size, then merge.
     *
     * int* arra[]  array which is to be sorted
     * int* arrb[]  help array
     * int start    starting index of the array
     * int end      right index of the array
     * int middle   resulting middle index of the array
     */
    int middle;

    if (start < end) {
        middle = (start + end) / 2;
        Merge_Sort(arra, arrb, start, middle);
        Merge_Sort(arra, arrb, middle + 1, end);
        Merge(arra, arrb, start, middle, end);
    }
}

void printArray(int arr[], int size, int procID) {
    /*
     * Prints an array in the terminal.
     *
     * int arr[]    array which is to be printed
     * int size     size of the array
     */
    for (int i = 0; i < size; i++) {
        printf("%d: %d\n", procID, arr[i]);
    }
    printf("\n");
}

void printMasterWorkerPackages(int myid, int* sub, int local_size) {
    /*
     * Prints the received packages for master and workers in the terminal.
     *
     * int myid         IDs of the processes
     * int* sub         pointer to the arrays from the processes
     * int local_size   size of the pointed arrays
     */
    if (myid == 0) {
        printf("Master %d got packages:\n", myid);
        printArray(sub, local_size, myid);
    }
    else {
        printf("Worker %d got packges:\n", myid);
        printArray(sub, local_size, myid);
    }
}

int main(int argc, char* argv[]) {
    /*
     * Main function of the algorithm.
     *
     * int* arr             pointer to the array space which is to be sorted
     * int* arr_dist        pointer to the array space which is distributed by scatter
     * int numprocs         number of processes
     * int myid             IDs of the processes
     * int length           number of elements in the array
     * int local_size       size of each local array for each process
     * int* sub             pointer to the array space for each local array
     * int* result          pointer to the array space for the sorted array
     * int* tmp_for_last    pointer to the array space for the final merge
     * double tstamp1,      time stamp variables for the time measurement
     *  tstamp2, tdiff      
     * int height           number of levels of the merge sort algorithm
     * int current_height   current height for the processes
     * int receiver_id,     ID of the sender and receiver process
     *  sender_id           
     * int* half1, half2    first and second half of the array to be merged
     * int* both_half       both halfs combined
     * double mod2_procs    help variable to control the number of processes
     * int rest             help variable to find out if all elements of the array were considered
     * int cmp_myid         help variable to decide whether the process is sender or receiver at the current height
     */
    int* arr;
	int* arr_dist;
    int numprocs;
    int myid;
    int length;
    int local_size;
    int* sub;
    int* result = NULL;
    int* tmp_for_last;
    double tstamp1, tstamp2, tdiff;
    int height;
    int current_height;
    int receiver_id, sender_id;
    int* half1;
    int* half2;
    int* both_halfs;
	double mod2_procs;

    srand(time(NULL));

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myid);

    // check arguments: argument size of array expected.
    if (argc != 2) {
        if (myid == 0) printf("\n%s: usage %s size \n", argv[0], argv[0]);
        MPI_Finalize();
        exit(1);
    }

    // get size of the array. If the user enters a size <= 0, exit code!
    length = atoi(argv[1]);
    if (length <= 0) {
        if (myid == 0) printf("\n%s: size %d should be > 0! \n", argv[0], length);
        MPI_Finalize();
        exit(1);
    }

    // control the given number of processes. If the number has not the base of 2, exit code!
    mod2_procs = log2(numprocs);
    if (mod2_procs > (int)floor(mod2_procs)) {
        if (myid == 0) printf("\nPlease choose a number of processes that has base of 2.\n");
        MPI_Finalize();
        exit(1);
    }

    // fill array with random numbers
    if (myid == 0) {
        arr = (int*)malloc(length * sizeof(int));
        if (arr == NULL) {
            printf("Memory not allocated.\n");
            MPI_Finalize();
            exit(1);
        }
        else {
            for (int i = 0; i < length; i++)
                arr[i] = rand();
				//arr[i] = i;
        }
    }
    if (DEBUG == 1) {
        if (myid == 0) {
            printf("%d: Array generated!\n", myid);
            printArray(arr, length, myid);
        }
    }
    //calculate size of (local) array required by each process
    //  and open up space for array used by it
    local_size = length / numprocs;
    sub = (int*)malloc(local_size * sizeof(int));
	
	int rest;
    rest = length % numprocs;

	arr_dist = (int*)malloc((length - rest) * sizeof(int));
	
	if (myid == 0){
		for(int i=0; i<length-rest; i++){
			arr_dist[i] = arr[i];
		}
        if (DEBUG == 1) {
            printf("\n\nRest: %d; length: %d, local_size: %d\n\n", rest, length, local_size);
            printf("\n\narr_dist:\n\n");
            printArray(arr_dist, length-rest, 0);
        }
	}
	
    // calculate the height (steps) for the merge sort algorithm
	height = log2(numprocs);
	
	MPI_Scatter(arr_dist, local_size, MPI_INT, sub, local_size, MPI_INT, 0, MPI_COMM_WORLD);
	tstamp1 = MPI_Wtime();

    if (DEBUG == 1) {
        printf("%d/%d: >0< Got packages from scatter:\n", myid, current_height);
        printArray(sub, local_size, myid);
    }

    // temporary array half1 needed for merge sort
    half1 = (int*)malloc(local_size * sizeof(int));
    current_height = 0;

    // each process is either a receiver or a sender at different heights.
    //  start while loop for each height and process.
    while (current_height < height - 1) {
        // sort the array for each process and calculate the resulting time needed to do this
        Merge_Sort(sub, half1, 0, local_size - 1);
		
        // is the process sender or receiver?
        int cmp_myid = myid % (2 * (int)pow(2, current_height));
        if (cmp_myid == 0 || myid == 0) {	
            // receiver processes
            // determine the ID of the sender process
            sender_id = myid + pow(2, current_height);
            if (DEBUG == 1)
                printf("%d/%d: sender_id = %d\n", myid, current_height, sender_id);
            
            // open up array space for the data package from sender process
            half2 = (int*)malloc(local_size * sizeof(int));
            // open up array space to combine both parackes
            both_halfs = (int*)malloc(local_size * 2 * sizeof(int));

            // Receive data package
			MPI_Recv(half2, local_size, MPI_INT, sender_id, current_height, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            if (DEBUG == 1) {
                printf("%d/%d: >1< Got packages from %d with:\n", myid, current_height, sender_id);
                printArray(half2, local_size, myid);
            }

            // combine both packages
            for (int i = 0; i < local_size; i++) {
                both_halfs[i] = half1[i];
                both_halfs[i + local_size] = half2[i];
            }
            if (DEBUG == 1) {
                printf("%d/%d: >2< Both halfs are: \n", myid, current_height);
                printArray(both_halfs, local_size * 2, myid);
            }

            // Preparation for the next step: double the array size
            local_size = local_size * 2;
            half1 = realloc(half1, local_size * sizeof(int));
            sub = realloc(sub, local_size * sizeof(int));
            for (int i = 0; i < local_size; i++) {
                sub[i] = both_halfs[i];
            }

            free(half2);
            free(both_halfs);
        }
        else {
            // sender processes
            // determine the ID of the receiver process
            receiver_id = myid - pow(2, current_height);

            // Send data package
            MPI_Send(half1, local_size, MPI_INT, receiver_id, current_height, MPI_COMM_WORLD);
            if (DEBUG == 1)
                printf("%d/%d: receiver_id = %d\n", myid, current_height, receiver_id);

            // end while loop for sender process
            current_height = height;
        }
        current_height++;
    }

    free(half1);
    
    // open up the array space required for the result (as large as input array)
    //  -> only necessary for master
	if (myid == 0){
		result = (int*)malloc(length * sizeof(int));
		
		for (int i = 0; i < local_size; i++){
			result[i] = sub[i];
		}
		
        // in case not all elements of the array could be divided evenly accross the processes the master will
        // take care of the remaining elements in the final merge
		if (rest != 0) {
            for (int i = local_size; i < length; i++) {
                result[i] = arr[i];
            }
        }
		
		tmp_for_last = malloc(length * sizeof(int));
		
        if (DEBUG == 1) {
            printf("Array before last merge:\n");
            printArray(result, length, myid);
        }

		Merge_Sort(result, tmp_for_last, 0, length - 1);
		
        if (DEBUG == 1) {
            printf("\nArray after final merge:\n");
            printArray(result, length, myid);
        }

		tstamp2 = MPI_Wtime();
		tdiff = tstamp2 - tstamp1;

        printf("\n\nRuntime: %f\n\n", tdiff);
	}

    free(sub);
    //free(half1);

    MPI_Finalize();
    return 0;
}
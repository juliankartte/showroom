/*
 *  MPI Implementation of the Merge Sort Algorithm - approach 1
 *
 *  by Julian Kartte
 */

#include <stdio.h>
#include <mpi.h>
#include <stdlib.h>
#include <time.h>

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
        if (left_array[left_index] <= left_array[right_index])
            right_array[index++] = left_array[left_index++];
        else
            right_array[index++] = left_array[right_index++];
    }

    // if elements are left, add in array right_array
    if (left_index <= middle_index) {
        for (i = left_index; i <= middle_index; i++)
            right_array[index++] = left_array[i];
    }
    if (right_index <= end_index) {
        for (i = right_index; i <= end_index; i++)
            right_array[index++] = left_array[i];
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
     * int numprocs         number of processes
     * int myid             IDs of the processes
     * int length           number of elements in the array
     * int local_size       size of each local array for each process
     * int* sub             pointer to the array space for each local array
     * int* temp            pointer to the temporary space
     * int* result          pointer to the array space for the sorted array
     * int* tmp_for_last    pointer to the array space for the final merge
     * double tstamp1,      time stamp variables for the time measurement
     *  tstamp2, tdiff
     * int rest             help variable to find out if all elements of the array were considered
     */
    int* arr;
    int numprocs;
    int myid;
    int length;
    int local_size;
    int* sub;
    int* tmp;
    int* result = NULL;
    int* tmp_for_last;
    double tstamp1, tstamp2, tdiff;

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

    // fill array with random numbers
    if (myid == 0) {
        arr = (int*)malloc(length * sizeof(int));
        if (arr == NULL) {
            if (myid == 0) printf("Memory not allocated.\n");
            MPI_Finalize();
            exit(1);
        }
        else {
            for (int i = 0; i < length; i++)
                arr[i] = rand();
        }
    }

    if (DEBUG == 1) {
        if (myid == 0) {
            printf("%d: Array generated!\n", myid);
            printArray(arr, length, myid);
        }
    }

    // calculate size of local array required by each process
    //  and open up space for array used by it
    local_size = length / numprocs;
    sub = (int*)malloc(local_size * sizeof(int));

    //distribute array chunks to processes
    MPI_Scatter(arr, local_size, MPI_INT, sub, local_size, MPI_INT, 0, MPI_COMM_WORLD);
    tstamp1 = MPI_Wtime();

    if (DEBUG == 1)
        printMasterWorkerPackages(myid, sub, local_size);

    // temporary array needed for merge sort
    tmp = (int*)malloc(local_size * sizeof(int));

    // sort the array for each process and calculate the resulting time needed to do this
    Merge_Sort(sub, tmp, 0, local_size - 1);

    // open up the array space required for the result (as large as input array)
    //  -> only necessary for master
    if (myid == 0) {
        result = (int*)malloc(length * sizeof(int));
    }

    //collect sorted local arrays at master (process 0)
    MPI_Gather(sub, local_size, MPI_INT, result, local_size, MPI_INT, 0, MPI_COMM_WORLD);

    if (myid == 0) {
        int rest;
        rest = length % numprocs;

        // in case not all elements of the array could be divided evenly accross the processes the master will
        // take care of the remaining elements in the final merge
        if (rest != 0) {
            for (int i = local_size * numprocs; i < length; i++) {
                result[i] = arr[i];
            }
        }

        tmp_for_last = malloc(length * sizeof(int));	//open up space for final merge sort
        if (DEBUG == 1) {
            printf("\nThe result before the last MergeSort is: \n");
            printArray(result, length, myid);
        }
        Merge_Sort(result, tmp_for_last, 0, length - 1);

        if (DEBUG == 1) {
            printf("\nThe result is: \n");
            printArray(result, length, myid);
        }

        tstamp2 = MPI_Wtime();
        tdiff = tstamp2 - tstamp1;
        
        printf("\n\nRuntime: %f\n\n", tdiff);

        free(result);
        free(tmp_for_last);
    }
    free(sub);
    free(tmp);

    MPI_Finalize();
    return 0;
}
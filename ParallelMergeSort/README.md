# Goal
In this project the merge sort algorithm is to be parallelized by splitting the work between different processes. Two different approaches were implemented, both will be described shortly in the following.

## Basics
Merge sort works by splitting an array into smaller and smaller pieces, until only atomic elements are left. Then neighbouring elements are compared and combined in an ascending order. This process is then repeated, until all elements are combined and sorted.

<img src="https://user-images.githubusercontent.com/82139186/216347074-4d6df1bf-d6dc-451d-982b-bc3e9a6a3b29.png" alt="drawing" width="400"/>

## Implementation
The execution via mpi takes the number of processes used and the size of the array that should be sorted as input. The array is filled with random numbers. In a first step, the array is split into two parts, *arr_dist* and *rest*, were the length of *arr_dist* must be divisible by the number of processes used. *arr_dist* is then splitted into batches that get distributed via  *MPI_Scatter* to the different processes.

<img src="https://user-images.githubusercontent.com/82139186/216348908-ee4285ee-e188-46d6-a899-57d9bf6a8e1d.png" alt="drawing" width="400"/>

### First Approach: MergeSort_1.c
In the first approeach each process sorts its batch (in parallel). All sorted batches are then collected by the process 0 via *MPI_Gather*, combined with *rest* and merged one final time.
<img src="https://user-images.githubusercontent.com/82139186/216349671-f6bc79ef-61ac-4071-bfd5-eb29fbbdd248.png" alt="drawing" width="400"/>


### First Approach: MergeSort_2.c
In the second approach several processes 𝑝 with 𝑙𝑜𝑔2(𝑝) = 𝑥 ∈ ℕ is mandatory. In this approach every 
second active process sorts its batch and will then send it via MPI_Send to the next active neighbour who 
has a smaller ID. The receiver will first sort its own batch and then receive the batch from the sender via 
MPI_Recv. Both batches combined will then be sorted again. This process is repeated until only the master 
(process 0) is active, who at this point did collect all the previously scattered batches. In the last step the 
master will also collect the array rest and will run Merge_Sort one final time with all elements.

<img src="https://user-images.githubusercontent.com/82139186/216350075-4d0c21d1-2270-453d-93ec-d35d37505a74.png" alt="drawing" width="400"/>

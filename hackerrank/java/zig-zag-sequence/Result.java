import java.util.*;

public class Result {
    
    public static void findZigZagSequence(int[] a, int n) {
        Arrays.sort(a); // Sort the array first
        int mid = ((n + 1)/2) - 1; // Change #1: array is 0-indexed so subtract 1
        int temp = a[mid];
        a[mid] = a[n - 1]; // Move highest int to middle
        a[n - 1] = temp; // Move middle value to end
    
        int st = mid + 1;
        int ed = n - 2; // Change #2: we already process n-1, so do n-2
        while(st <= ed){
            temp = a[st];
            a[st] = a[ed];
            a[ed] = temp;
            st = st + 1;
            ed = ed - 1; // Change #3: need to decrement the end value to have st/ed meet
        }
        for(int i = 0; i < n; i++){
            if(i > 0) System.out.print(" ");
            System.out.print(a[i]);
        }
        System.out.println();
    }
}

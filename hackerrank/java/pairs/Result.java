import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Result {

	public static int pairs(int k, List<Integer> arr) {
        int totalPairs = 0;
        
        // The array is a set of unique integers (positive)
        HashSet<Integer> set = new HashSet<>(arr);
        
        for (Integer i : set) {
            // If the set contains i + k it means there exists a pair between i 
            // and the sum of i and k. We don't need to worry about double counting
            if (set.contains(i + k)) {
                totalPairs++;
            }
        }
        
        return totalPairs;
    }

}

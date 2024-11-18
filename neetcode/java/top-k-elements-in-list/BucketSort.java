import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class BucketSort {

	public static int[] topKFrequent(int[] nums, int k) {
		int[] results = new int[k];

		Map<Integer, Integer> numFrequency = new HashMap<>();
		List<List<Integer>> buckets = new ArrayList<>();

		// Populate each bucket with an empty arraylist
		IntStream.range(0, nums.length + 1).forEach(i -> {
			buckets.set(i, new ArrayList<>());
		});

		// Get frequency of numbers
		Arrays.stream(nums).forEach(num -> {
			numFrequency.put(num, numFrequency.getOrDefault(num, 0) + 1);
		});

		// Add values to the buckets - index is the frequency, values is an arraylist of numbers with that frequency
		numFrequency.entrySet().forEach(entry -> {
			buckets.get(entry.getValue()).add(entry.getKey());
		});
		
		// Descend the buckets from the top indices (most frequent) and stop when we hit 0 or k
		int kCounter = 0;
		for (int i = buckets.size(); i > 0 && i < k; i--) {
			for (Integer num : buckets.get(i)) {
				results[kCounter] = num;
				kCounter++;

				if (kCounter == k) {
					break;
				}
			}
		}
		
		return results;
    }

}

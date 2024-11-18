import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Result {

	public static int[] topKFrequent(int[] nums, int k) {
		int[] results = new int[k];

		Map<Integer, Integer> numFrequency = new HashMap<>();
		Arrays.stream(nums).forEach((num) -> {
			numFrequency.put(num, numFrequency.getOrDefault(num, 0) + 1);
		});


		// Setup a max heap
		PriorityQueue<int[]> maxHeap = new PriorityQueue<int[]>((a, b) -> a[0] - b[0]);

		// Add into the heap using the frequency as the weight
		for (Map.Entry<Integer, Integer> entry : numFrequency.entrySet()) {
			maxHeap.offer(new int[] { entry.getValue(), entry.getKey() });
			// Trim the heap to only have k elements
			if (maxHeap.size() > k) {
				maxHeap.poll();
			}
		}

        // Walk the heap to get the top k elements
		for (int i = 0; i < k; i++) {
			results[i] = maxHeap.poll()[1];
		}

		return results;
    }

}

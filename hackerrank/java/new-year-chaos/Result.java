import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Result {
    
    public static void minimumBribes(List<Integer> q) {
		assert 1 <= q.size();
		assert q.size() <= 100000;

		var minimumBribes = 0;

		int[] ref = new int[q.size()];

		// Set up a reference array which will be sorted according to the input queue
		for (int i = 0; i < q.size(); i++) { ref[i] = i + 1; }

		for (int i = 0; i < q.size(); i++) {
			var num = q.get(i);

			if (num == ref[i]) {
				// No bribe detected
				continue;
			} else {
				// Swap the current reference number with the next one to check if
				// this number was bribed only once
				var temp = ref[i];
				ref[i] = ref[i + 1];
				ref[i + 1] = temp;

				if (num == ref[i]) {
					minimumBribes += 1;
					continue;
				} else {
					// If that didn't match, then try swapping with two references ahead to
					// see if the number was bribed 2 times
					temp = ref[i];
					ref[i] = ref[i + 2];
					ref[i + 2] = temp;

					if (num == ref[i]) {
						// Number has moved ahead two
						minimumBribes += 2;
						continue;
					}
				}
			}

			// If nothing matched, then we end here and the queue was too chaotic
			System.out.println("Too chaotic");
			return;
		}

		System.out.println(minimumBribes);
    }
}

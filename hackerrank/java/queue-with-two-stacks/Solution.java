import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Solution {

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(System.out));
        
        int q = Integer.parseInt(reader.readLine().trim());
        
		Queue<Integer> queue = new Queue<Integer>();
        IntStream.range(0, q).forEach(iItr -> {
            try {
				int[] type = Arrays.stream(reader.readLine().trim().split(" ")).mapToInt(Integer::valueOf).toArray();

				assert type.length > 0;

				switch (type[0]) {
					case 1: {
						queue.enqueue(type[1]);
						break;
					}
					case 2: {
						queue.dequeue();
						break;
					}
					case 3: {
						writer.write(String.valueOf(queue.peek().orElseThrow()));
						writer.newLine();
					}
				}
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        });

		writer.flush();
    }
}

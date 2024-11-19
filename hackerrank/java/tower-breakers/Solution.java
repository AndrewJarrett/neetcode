import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Solution {

    public static void main(String[] args) throws IOException {
		BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));
		BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter(System.out));

		int t = Integer.parseInt(bufferedReader.readLine().trim());

		IntStream.range(0, t).forEach(tItr -> {
			try {
				String[] firstMultipleInput = bufferedReader.readLine().replaceAll("\\s+$", "").split(" ");

				int n = Integer.parseInt(firstMultipleInput[0]);

				int m = Integer.parseInt(firstMultipleInput[1]);

				int result = Result.towerBreakers(n, m);

				bufferedWriter.write(String.valueOf(result));
				bufferedWriter.newLine();
			} catch (IOException ex) {
				throw new RuntimeException(ex);
			}
		});

		bufferedReader.close();
		bufferedWriter.close();
	}
}


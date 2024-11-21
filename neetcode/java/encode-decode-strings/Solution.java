import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Solution {

    public static void main(String[] args) throws IOException {
		BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));
        BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter(System.out));

        List<String> strs = Arrays.asList(bufferedReader.readLine().replaceAll("\\s+$", "").split(" "));

		Result res = new Result();
        String encoded = res.encode(strs);
		bufferedWriter.write("Encoded: " + encoded);
        bufferedWriter.newLine();

		List<String> decoded = res.decode(encoded);
		bufferedWriter.write("Decoded: " + decoded.toString());
        bufferedWriter.newLine();

		// Test that original list and the decoded list are the same
		assert strs.equals(decoded);

		bufferedWriter.flush();

        bufferedReader.close();
        bufferedWriter.close();
    }

}

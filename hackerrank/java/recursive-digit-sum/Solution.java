import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Solution {

    public static void main(String[] args) throws IOException {
		//BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));
		BufferedReader bufferedReader = new BufferedReader(new FileReader("1.txt"));
        BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter(System.out));

		String[] firstMultipleInput = bufferedReader.readLine().replaceAll("\\s+$", "").split(" ");
        String n = firstMultipleInput[0];
        int k = Integer.parseInt(firstMultipleInput[1]);

        long result = Result.superDigit(n, k);

        bufferedWriter.write(String.valueOf(result));
        bufferedWriter.newLine();

        bufferedReader.close();
        bufferedWriter.close();
	}
}


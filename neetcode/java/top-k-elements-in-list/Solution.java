import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Solution {

    public static void main(String[] args) throws IOException {
		BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));
        BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter(System.out));

        int k = Integer.parseInt(bufferedReader.readLine().replaceAll("\\s+$", ""));

        String[] numsTemp = bufferedReader.readLine().replaceAll("\\s+$", "").split(" ");

        int[] nums = new int[numsTemp.length];

		for (int i = 0; i < nums.length; i++) {
            int num = Integer.parseInt(numsTemp[i]);
            nums[i] = num;
        }

        int[] result = Result.topKFrequent(nums, k);

		for (int j = 0; j < k; j++) {
			bufferedWriter.write(String.valueOf(result[j]) + " ");
		}
        bufferedWriter.newLine();

		bufferedWriter.flush();

        bufferedReader.close();
        bufferedWriter.close();
    }

}

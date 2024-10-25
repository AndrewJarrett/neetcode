import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Solution {

    public static void main(String[] args) {
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			Integer t = Integer.valueOf(br.readLine());
			
			IntStream.range(0, t).forEach(test -> {
				try {
					Integer n = Integer.valueOf(br.readLine());
					
					int[] a = Arrays.stream(br.readLine().split(" ")).mapToInt(Integer::valueOf).toArray();
					Result.findZigZagSequence(a, n);
				} catch (IOException e) {
					System.out.println("Something was wrong with the IO!");
					System.out.println("Exception: " + e.getMessage());
				}
			});
		} catch (IOException e) {
			System.out.println("Something was wrong with the IO!");
			System.out.println("Exception: " + e.getMessage());
		}
    }
}


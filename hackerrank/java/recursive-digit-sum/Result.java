import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Result {
    
    public static long superDigit(String n, int k) {
		assert 1 <= n.length();
		assert n.length() <= Integer.MAX_VALUE;
		assert 1 <= k;
		assert k <= 100000;

		long sum = 0;

		if (n.length() == 1) {
			sum = Integer.valueOf(n);
		} else {
			sum = n.chars()
				.map(c -> Character.getNumericValue(c))
				.reduce(0, (acc, i) -> acc + i);

			// We don't need to concatenate since the sum of
			// n repeated k times is the same as the sum of n
			// times k
			sum *= k;

			// There is a relationship between the digit sum of a number
			// and that number modulus 9. The remainder after dividing by 
			// 9 (sum mod 9) is the digit sum unless the sum is divisible 
			// by 9 itself (in which case the digit sum is 9).
			sum = sum % 9 == 0 ? 9 : sum % 9;
		}

		return sum;
    }
}

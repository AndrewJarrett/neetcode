import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Result {
    
    public static int palindromeIndex(String s) {
		int result = -1;
		int i = getIndex(s);

		if (i == -1) {
			return result;
		}

		int j = s.length() - 1 - i;
		String left = s.substring(0, i) + s.substring(i + 1, s.length());
		String right = s.substring(0, j) + s.substring(j + 1, s.length());

		if (getIndex(left) == -1) {
			result = i;
		} else if (getIndex(right) == -1) {
			result = j;
		}

		return result;
    }

	private static int getIndex(String s) {
		int index = -1;

		if (s.length() == 1 || s.length() == 2 && s.charAt(0) == s.charAt(1)) {
			return index;
		}

		for (int i = 0; i < s.length() / 2; i++) {
			if (s.charAt(i) != s.charAt(s.length() - 1 - i)) {
				index = i;
				break;
			}
		}

		return index;
	}

}

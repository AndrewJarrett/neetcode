import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Result {
    
    public static String caesarCipher(String s, int k) {
		final int r = k % 26; // We don't need to add more than 26 letters
		
		HashSet<Character> lower = new HashSet<>();
		HashSet<Character> upper = new HashSet<>();
		for (int i = 0; i < 26; i++) {
			lower.add((char) ('a' + i));
			upper.add((char) ('A' + i));
		}

		char[] chars = s.toCharArray();
		for (int i = 0; i < s.length(); i++) {
			char c = chars[i];
			if (lower.contains(c)) {
				chars[i] = (char) ('a' + (((c - 'a') + r) % 26));
			} else if (upper.contains(c)) {
				chars[i] = (char) ('A' + (((c - 'A') + r) % 26));
			}
		}

		return new String(chars);
    }

}

import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Result {
	int start = 0;
	int current = 0;

	public String encode(List<String> strs) {
		String encoded = "";

		// Have a prefix that has the length of the string with 
		// a separator, then the string
		for (String s : strs) {
			encoded += s.length() + ":" + s;
		}

		return encoded;
    }

	public List<String> decode(String str) {
		List<String> strs = new ArrayList<>();

		int length = 0;
		while (!isAtEnd(str)) {
			String newStr = "";

			start = current;
			Character c = advance(str);
			switch (c) {
				case '0' -> {
					strs.add("");
					advance(str);
				}
				case '1','2','3','4','5','6','7','8','9' -> {
					// Find the length of the string
					String numStr = number(str);
					length = Integer.valueOf(numStr);

					// Update start to being at the index of the word
					start = current;
					advance(str);

					// Get the actual string
					current += length - 1;
					newStr = str.substring(start, current);
					length = 0;
					strs.add(newStr);
				}
			}
		}

		return strs;
	}

	String number(String str) {
		String numStr = "";

		Optional<Character> peekC = peek(str);
		while (peekC.isPresent() && isDigit(peekC.get())) {
			advance(str);
			peekC = peek(str);
		}

		peekC = peek(str);
		if (peekC.isPresent() && peekC.get() == ':') {
			numStr = str.substring(start, current);
			advance(str);
		}

		return numStr;
	}

	Optional<Character> peek(String str) {
		Optional<Character> c = Optional.empty();
		if (!isAtEnd(str)) {
			c = Optional.of(str.charAt(current));
		}
		return c;
	}

	Character advance(String str) {
		Character c = str.charAt(current);
		current++;
		return c;
	}

	boolean isDigit(Character c) {
		boolean isDigit = false;
		switch (c) {
			case '0','1','2','3','4','5','6','7','8','9' -> isDigit = true;
		}
		return isDigit;
	}

	boolean isAtEnd(String str) {
		boolean isAtEnd = false;
		if (current >= str.length() || str.length() == 1) {
			isAtEnd = true;
		}
		return isAtEnd;
	}

}

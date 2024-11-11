import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Result {

	public static String isBalanced(String s) {
		Boolean isBalanced = true;

		if (s.length() % 2 != 0) {
			isBalanced = false;
		} else {
			HashMap<Character, Character> leftBrackets = new HashMap<>();
			leftBrackets.put('(', ')');
			leftBrackets.put('{', '}');
			leftBrackets.put('[', ']');

			HashMap<Character, Character> rightBrackets = new HashMap<>();
			rightBrackets.put(')', '(');
			rightBrackets.put('}', '{');
			rightBrackets.put(']', '[');

			Stack<Character> left = new Stack<>();
			Stack<Character> right = new Stack<>();

			for (Character c : s.toCharArray()) {

				if (leftBrackets.keySet().contains(c)) {
					if (!right.empty()) {
						Character rc = right.pop();

						if (rightBrackets.get(rc) != c) {
							isBalanced = false;
							break;
						}
					} else {
						left.push(c);
					}
				} else if (rightBrackets.keySet().contains(c)) {
					if (!left.empty()) {
						Character lc = left.pop();

						if (leftBrackets.get(lc) != c) {
							isBalanced = false;
							break;
						}
					} else {
						right.push(c);
					}
				} else {
					isBalanced = false;
					break;
				}
			}

			if (!left.empty() || !right.empty()) {
				isBalanced = false;
			}
		}

		return isBalanced ? "YES" : "NO";
	}
}

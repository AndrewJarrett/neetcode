import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Result {

	public static String encode(List<String> strs) {
		String encoded = "";
		
		for (String s : strs) {
			encoded += s + "-";
		}

		return encoded;
    }

	public static List<String> decode(String str) {
		List<String> strs = new ArrayList<>();

		if (str.length() > 1) {
			strs = Arrays.asList(str.split("-"));
		} else if (str.length() == 1) {
			strs.add("");
		}

		return strs;
	}

}

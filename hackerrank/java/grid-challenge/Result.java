import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Result {
    
    public static String gridChallenge(List<String> grid) {
		boolean canRearrange = true;

		assert 1 <= grid.size();
		assert grid.size() <= 100;

		for (int i = 0; i < grid.size() - 1; i++) {
			if (i == 0) {
				char[] temp = grid.get(i).toCharArray();
				Arrays.sort(temp);
				grid.set(i, new String(temp));
			}

			char[] temp = grid.get(i + 1).toCharArray();
			Arrays.sort(temp);
			grid.set(i + 1, new String(temp));

			// Since we sorted this row and the next, we can compare the columns
			// There is only one way for the row to be sorted ascending, so if
			// the columns are also not ascending, then this cannot be rearranged.
			for (int j = 0; j < grid.get(i).length(); j++) {
				if (grid.get(i).charAt(j) > grid.get(i + 1).charAt(j)) {
					canRearrange = false;
					break;
				}
			}
		}

		return canRearrange ? "YES" : "NO";
    }
}

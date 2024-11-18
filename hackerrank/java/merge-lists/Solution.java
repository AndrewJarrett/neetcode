import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Solution {

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        
        int t = Integer.parseInt(reader.readLine().trim());
        
        IntStream.range(0, t).forEach(iItr -> {
            try {
                int n = Integer.parseInt(reader.readLine().trim());
                
                Result.SLL<Integer> a = new Result.SLL<Integer>();
                IntStream.range(0, n).forEach(nItr -> {
                    try {
                        Integer num = Integer.parseInt(reader.readLine().trim());
                        a.append(num);
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                });
                
                int m = Integer.parseInt(reader.readLine().trim());
                
                Result.SLL<Integer> b = new Result.SLL<Integer>();
                IntStream.range(0, m).forEach(mItr -> {
                    try {
                        Integer num = Integer.parseInt(reader.readLine().trim());
                        b.append(num);
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                });
                
                Result.SLL<Integer> result = Result.mergeLists(a, b);
                System.out.println(result);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        });
    }
}

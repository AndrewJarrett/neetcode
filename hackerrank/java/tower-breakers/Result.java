import java.util.*;

public class Result {
    
    public static int towerBreakers(int n, int m) {
		int winner = 1;
        
        // Either n (number of towers) is odd or even.
        // Odd number of towers: the players will always mirror each other and 
        // remove the fewest pieces possible. This means that if Player 1 starts
        // first, then player 1 will win since they will be the first to remove 
        // all pieces except for the last one.
        
        // Even number of towers: likewise, if there are an even number of towers,
        // then Player 1 will go first which means that Player 2 will be able to
        // remove all pieces except for one last, which means Player 1 has no more
        // moves and loses.
        
        // The last edge case is if the size of the towers is 1 then player 1 
        // loses since there are no possible moves.
        
        if (m == 1 || n % 2 == 0) {
            winner = 2;
        }
        
        return winner;
    }

}

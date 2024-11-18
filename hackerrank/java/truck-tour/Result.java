import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Result {
    
    public static int truckTour(List<List<Integer>> petrolpumps) {
		int startingStation = 0;
        int totalPumps = petrolpumps.size();

		assert 1 <= totalPumps;
		assert totalPumps <= 100000;
        
        for (int start = 0; start < totalPumps; start++) {
            List<Integer> stationInfo = petrolpumps.get(start);
            int petrol = stationInfo.get(0);
            int distance = stationInfo.get(1);

			assert 1 <= petrol;
			assert petrol <= 100000;
			assert 1 <= distance;
			assert distance <= 100000;
				
            // This is a valid starting location
            if (petrol > distance) {
                // Reset the petrol for this test
                int totalPetrol = 0;
                Boolean isLoopCompleted = true;
                
                for (int offset = 0; offset < totalPumps; offset++) {
                    // Ensure we loop from the end to the beginning
                    stationInfo = petrolpumps.get((start + offset) % totalPumps);
                    petrol = stationInfo.get(0);
                    distance = stationInfo.get(1);

					assert 1 <= petrol;
					assert petrol <= 100000;
					assert 1 <= distance;
					assert distance <= 100000;
                    
                    totalPetrol += (petrol - distance);
                    
                    // Fuel up the total and then subtract the distance to the next
                    // station. If we don't have any fuel left then break and test
                    // the next station.
                    if (totalPetrol < 0) {
                        isLoopCompleted = false;
                        
                        // Since we know that at this point offset, the combination of
                        // fuel and distance will not allow the truck to complete
                        // the tour, we can jump start ahead to start at start + offset (offset is the 
						// offset from start)
                        start = start + offset;
                        break;
                    }
                }
            
                if (isLoopCompleted) {
                    startingStation = start;
                    break;
                }
            }
        }
        
        return startingStation;
    }
}

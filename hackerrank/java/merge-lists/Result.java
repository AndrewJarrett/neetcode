import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Result {
    
    public static class SLL<T> {
        Optional<SLLNode<T>> head;
        Optional<SLLNode<T>> tail;
        int size;
        
        public SLL() {
            this.head = Optional.empty();
            this.tail = Optional.empty();
            size = 0;
        }
        
        public Optional<T> peek() {
            if (this.head.isPresent()) {
                return Optional.of(this.head.get().data);
            } else {
                return Optional.empty();
            }
        }
        
        public Optional<T> pop() {
            // Return empty value if head doesn't exist
            if (this.head.isEmpty()) {
                return Optional.empty();
            }
            
            // Point head to next (can be empty optional)
            SLLNode<T> currentHead = this.head.get();
            this.head = currentHead.next;
            
            // Remove tail if we popped the last node
            if (currentHead == this.tail.get()) {
                this.tail = Optional.empty();
            }
            
            // Reduce size
            assert this.size > 0;
            this.size--;
            
            return Optional.of(currentHead.data);
        }
        
        public void append(T data) {
            Optional<SLLNode<T>> newNode = Optional.of(new SLLNode<T>(data));
            Optional<SLLNode<T>> currentTail = this.tail;
            
            // Update head to the new node if the head is null
            if (this.head.isEmpty()) {
                this.head = newNode;
            } else {
                // Add newNode to the end of the current tail in the list
                currentTail.get().next = newNode;
            }
            
            // Update tail pointer in all cases
            this.tail = newNode;
            
            // Increase size
            assert this.size >= 0;
            this.size++;
        }
        
        public int size() {
            return this.size;
        }
        
        public Boolean isEmpty() {
            return this.size == 0;
        }
        
        public String toString() {
            String toString = "";
            
            Optional<SLLNode<T>> node = this.head;
            while (node.isPresent()) {
                toString += String.valueOf(node.get().data) + " ";
                node = node.get().next;
            }
            
            return toString;
        }
    }
    
    public static class SLLNode<T> {
        Optional<SLLNode<T>> next;
        T data;
        
        public SLLNode(T newData) {
            this.next = Optional.empty();
            this.data = newData;
        }
    }
    
    public static SLL<Integer> mergeLists(SLL<Integer> a, SLL<Integer> b) {
        assert 1 <= a.size();
        assert a.size() <= 1000;
        assert 1 <= b.size();
        assert b.size() <= 1000;
        
        SLL<Integer> merged = new SLL<Integer>();
        while (!a.isEmpty() && !b.isEmpty()) {
            // Pick the lowest node from a or b and connect them in the correct order into "merged" list
            if (a.peek().orElse(0) < b.peek().orElse(0)) {
                merged.append(a.pop().get());
            } else {
                merged.append(b.pop().get());
            }
            
            if (a.isEmpty()) {
                // Add b to the tail of the merged list if a is empty
                merged.tail.get().next = b.head;
                merged.tail = b.tail;
            } else if (b.isEmpty()) {
                merged.tail.get().next = a.head;
                merged.tail = a.tail;
            }
        }
        
        return merged;
    }
    
}

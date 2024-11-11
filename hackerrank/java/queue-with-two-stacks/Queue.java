import java.io.*;
import java.util.*;
import java.util.stream.*;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public class Queue<T> {
	Stack<T> in = new Stack<T>();
	Stack<T> out = new Stack<T>();

	public Optional<T> peek() {
		Optional<T> value;

		// Move the elements from in to the out stack only if
		// the out stack is empty
		if (out.empty()) {
			while (!in.empty()) {
				out.push(in.pop());
			}
		}

		try {
			value = Optional.of(out.peek());
		} catch (EmptyStackException e) {
			value = Optional.empty();
		}

		return value;
	}

	public void enqueue(T element) {
		// Just enqueue on the input stack
		in.push(element);
	}

	public Optional<T> dequeue() {
		Optional<T> value;

		// Move the elements from the in stack to the out
		// stack only if the out stack is empty
		if (out.empty()) {
			while (!in.empty()) {
				out.push(in.pop());
			}
		}

		// Now pop this element from the "top" of the alt stack
		try {
			value = Optional.of(out.pop());
		} catch (EmptyStackException e) {
			value = Optional.empty();
		}

		return value;
	}
}

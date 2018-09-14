	public static <T> LinkedList<T> reverse(final LinkedList<T> origin){
		if(origin == null){
			throw new NullPointerException("Cannot reverse a null LinkedList")
		}
		if(origin.getNext() == null){
			return origin;
		}
		final LinkedList<T> next =  origin.next;
		origin.next = null;

		final LinkedList<T> next = origin.next;
		origin.next = null;

		final LinkedList<T> otherReversed = reverse(next);

		next.next = origin;

		return otherReversed;
	}
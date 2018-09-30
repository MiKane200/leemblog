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

	基础双向链表的插入实现：
	有结构 A(未知) <=> p <=> B(未知)
	在p B之间插入一个s，所以有
	1、s->prior = p;
	2、s->next = p->next;(1、2要先手)
	3、p->next->prior = s;(这一步一定要在第四步前，不能影响p->next的指向)
	4、p->next = s;

	删除操作：
	p->prior->next = p->next;
	p->next->prior = p->prior;
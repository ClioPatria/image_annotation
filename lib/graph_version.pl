:- module(graph_version,
	  [gv_resource_commit/5,
	   gv_resource_head/2,
	   gv_resource_graph/2
	  ]).

:- use_module(library('semweb/rdf_db')).
:- use_module(library('semweb/rdfs')).

:- meta_predicate
	gv_resource_commit(+,+,0,-,-).

%%      gv_resource_commit(+Resource, +User, :Action, -Commit, -Graph)
%
%	Performs Action on the most recent versioned named graph
%	associated with Resource, and stores the result in Graph.
%	The action is commited by creating a Commit object, this object
%	links with:
%	* gv:parent to the previous commit
%	* gv:graph to Graph
%	* dc:creator to User
%	* dc:date to th current time

gv_resource_commit(Resource, User, Action, Commit, Graph) :-
	get_time(TimeStamp),
	gv_resource_head(Resource, ParentCommit),
	gv_resource_graph(ParentCommit, ParentGraph),
	rdf_bnode(Graph),
	rdf_bnode(Commit),
	copy_rdf_graph(ParentGraph, Graph),
	rdf_transaction(Action),
	rdf_transaction((rdf_assert(Commit, gv:parent, ParentCommit, Commit),
			 rdf_assert(Commit, gv:graph, Graph, Commit),
			 rdf_assert(Commit, dc:creator, User, Commit),
			 rdf_assert(Commit, dc:date, literal(TimeStamp), Commit))),
	gv_move_resource_head(Resource, Commit).

%%	gv_resource_head(+Resource, -Commit) is det.
%
%	Commit is the most recent commit on the versioned graphs
%	associated with Resource, or the value 'init' if there are no
%	versioned graphs associated with resource.
%
gv_resource_head(Resource, Commit) :-
	rdf(Commit, gv:head, Resource),
	!.
gv_resource_head(_, init).

%%	gv_resource_graph(Commit, Graph) is det.
%
%	Graph is the versioned graph checked in by Commit, or the value
%	'init' if Commit == 'init'. The latter is ensures that every
%	Commit value generated by gv_resource_head/2 can be used as
%	the first argument to gv_resource_graph/2.

gv_resource_graph(init, init) :- !.
gv_resource_graph(Commit, Graph) :-
	rdf(Commit, gv:graph, Graph),!.

%%	gv_move_resource_head(+Resource, +Commit) is det.
%
%	Make Commit the new head of the branch associated with
%	Resource.
%
gv_move_resource_head(Resource, Commit) :-
	(   rdf(Parent, gv:head, Resource)
	->  rdf_retractall(Parent, gv:head, Resource, heads)
	;   true
	),
	rdf_assert(Commit, gv:head, Resource, heads).



copy_rdf_graph(init, _) :- !.
copy_rdf_graph(From, To) :-
	rdf_transaction(forall(rdf(S,P,O,From),
			       rdf_assert(S,P,O,To))).

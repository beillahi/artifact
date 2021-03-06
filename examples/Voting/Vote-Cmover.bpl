// Vote Application
// Instead of having the number of votes per given pnb to be less than some maxNbVotes value
// in order to cast new vote we have that in order to cast new votes there must 
// exist two placement in the table VoterPhoneToVotesCount that are empty
// It has 1 transaction
// Movers check
// RUN: /usr/bin/time -v --format="%e" %boogie -noinfer -typeEncoding:m -tracePOs -traceTimes  -trace  -useArrayTheory "%s" > "%t"
// RUN: %diff "%s.expect" "%t"

type Pid;

type Cid;            // Contestant identifier
type Vid;           // Vote identifier
type Pnb;          // Phone number 
type Sid;         // State identifier
type Acd;        // Area code

function {:builtin "MapConst"} MapConstBool(bool) : [Pid]bool;
function {:inline} {:linear "pid"} PidCollector(x: Pid) : [Pid]bool
{
  MapConstBool(false)[x := true]
}

function {:builtin "MapConst"} MapConstBool2(bool) : [Vid]bool;
function {:inline} {:linear "vid"} VidCollector(x: Vid) : [Vid]bool
{
  MapConstBool2(false)[x := true]
}

var {:layer 0,2} ActiveContestant: [Cid]bool;
var {:layer 0,2} AreaToState: [Acd]Sid;
var {:layer 0,2} VoterPhoneToVotesCount: [Pnb][Vid]int;
var {:layer 0,2} VidValid: [Vid]bool;
var {:layer 0,2} VotesPnb: [Vid]Pnb;
var {:layer 0,2} VotesSid: [Vid]Sid;
var {:layer 0,2} VotesCid: [Vid]Cid;

///////////////////////////////////////////////////////////////////////////////

procedure {:right}{:layer 2}  addVoteR(cid:Cid, {:linear "vid"} vid: Vid, pnb: Pnb, acd: Acd)
{  
  assume(!VidValid[vid]);

  assume (ActiveContestant[cid] && VoterPhoneToVotesCount[pnb][vid] == 0 && (exists vid0:Vid:: vid0 != vid && VoterPhoneToVotesCount[pnb][vid0] == 0));
}
procedure{:yields}{:layer 1} {:refines "addVoteR"} AddVoteR(cid:Cid, {:linear "vid"} vid: Vid, pnb: Pnb, acd: Acd);

///////////////////////////////////////////////////////////////////////////////

procedure {:right}{:layer 2}  addVoteW(cid:Cid, {:linear "vid"} vid: Vid, pnb: Pnb, acd: Acd)
modifies VidValid, VotesCid, VotesPnb, VotesSid, VoterPhoneToVotesCount;
{  
  VidValid[vid] := true;
	VotesCid[vid] := cid;
  VotesPnb[vid] := pnb;
  VotesSid[vid] := AreaToState[acd];
  VoterPhoneToVotesCount[pnb][vid] := 1 ;
}
procedure{:yields}{:layer 1} {:refines "addVoteW"} AddVoteW(cid:Cid, {:linear "vid"} vid: Vid, pnb: Pnb, acd: Acd);

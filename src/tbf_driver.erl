%% @doc Protocol driver process for TBF (Thrift Binary Format)
%% protocol sessions.
%%
%% The process executing `loop()' in this module is represented in the
%% diagram below by the "UBF Driver" circle.
%% <img src="../priv/doc/ubf-flow-01.png"></img>

-module(tbf_driver).
-behavior(contract_driver).

-export([start/1, init/1, encode/2, decode/4]).

start(Contract) ->
    proc_utils:spawn_link_debug(fun() -> contract_driver:start(?MODULE, Contract) end, tbf_client_driver).

init(_Contract) ->
    tbf:decode_init().

encode(Contract, Term) ->
    tbf:encode(Term, Contract, get(?MODULE)).

decode(Contract, Cont, Binary, CallBack) ->
    Cont1 = tbf:decode(Binary, Contract, Cont),
    decode(Contract, Cont1, CallBack).

decode(_Contract, {more, _}=Cont, _CallBack) ->
    Cont;
decode(Contract, {ok, Term, Binary, VSN}=_Cont, CallBack) ->
    put(?MODULE, VSN),
    CallBack(Term),
    Cont1 = tbf:decode(Binary, Contract),
    decode(Contract, Cont1, CallBack).

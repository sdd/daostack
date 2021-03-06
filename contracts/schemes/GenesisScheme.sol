pragma solidity ^0.4.11;
import "../controller/Controller.sol";
import "../SimpleVoteInterface.sol";

////////////////////////////////////////////////////////////////////////////////


contract GenesisScheme {
    Controller public controller;
    SimpleVoteInterface public simpleVote;

    function GenesisScheme( string tokenName,
                            string tokenSymbol,
                            address[] _founders,
                            int[] _tokenAmount,
                            int[] _reputationAmount,
                            SimpleVoteInterface _simpleVote ) {

        controller = new Controller( tokenName, tokenSymbol, this);
        simpleVote = _simpleVote;
        simpleVote.setOwner(this);
        simpleVote.setReputationSystem(controller.nativeReputation());

        for( uint i = 0 ; i < _founders.length ; i++ ) {
            if( ! controller.mintTokens( _tokenAmount[i], _founders[i] ) ) revert();
            if( ! controller.mintReputation( _reputationAmount[i], _founders[i] ) ) revert();
        }
    }

    function proposeScheme( address _scheme ) returns(bool) {
        return simpleVote.newProposal(sha3(_scheme));
    }

    function voteScheme( address _scheme, bool _yes ) returns(bool) {
        if( ! simpleVote.voteProposal(sha3(_scheme),_yes, msg.sender) ) return false;
        if( simpleVote.voteResults(sha3(_scheme)) ) {
            if( ! simpleVote.closeProposal(sha3(_scheme) ) ) revert();
            if( controller.schemes(_scheme) ) {
                if( ! controller.unregisterScheme(_scheme) ) revert();
            }
            else {
                if( ! controller.registerScheme(_scheme) ) revert();
            }
        }

    }

    function getVoteStatus(address _scheme) constant returns(uint[4]) {
        return simpleVote.voteStatus(sha3(_scheme));
    }
}

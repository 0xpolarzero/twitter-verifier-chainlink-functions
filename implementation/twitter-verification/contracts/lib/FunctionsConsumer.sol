// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./dev/functions/FunctionsClient.sol";
// import "@chainlink/contracts/src/v0.8/dev/functions/FunctionsClient.sol"; // Once published
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

// ! -- OVERRIDEN BY THE IMPLEMENTATION --
// Turn an address into a string
function addressToString(address _addr) pure returns (string memory) {
  bytes32 value = bytes32(uint256(uint160(_addr)));
  bytes memory alphabet = "0123456789abcdef";
  bytes memory str = new bytes(42);
  str[0] = "0";
  str[1] = "x";

  for (uint256 i = 0; i < 20; i++) {
    str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
    str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
  }

  return string(str);
}

/**
 * @title Functions Copns contract
 * @notice This contract is a demonstration of using Functions.
 * @notice NOT FOR PRODUCTION USE
 */
contract FunctionsConsumer is FunctionsClient, ConfirmedOwner {
  using Functions for Functions.Request;

  bytes32 public latestRequestId;
  bytes public latestResponse;
  bytes public latestError;

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

  /**
   * @notice Executes once when a contract is created to initialize state variables
   *
   * @param oracle - The FunctionsOracle contract
   */
  constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {}

  /**
   * @notice Send a simple request
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   * @param subscriptionId Billing ID
   */
  function executeRequest(
    string calldata source,
    bytes calldata secrets,
    string[] calldata args,
    uint64 subscriptionId,
    uint32 gasLimit
  ) public onlyOwner returns (bytes32) {
    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
    if (secrets.length > 0) req.addInlineSecrets(secrets);

    // ! -- OVERRIDEN BY THE IMPLEMENTATION --
    // Turn the sender address into a string
    string memory sender = addressToString(msg.sender);

    // And add it to the args
    string[] memory newArgs = new string[](args.length + 1);
    for (uint256 i = 0; i < args.length; i++) {
      newArgs[i] = args[i];
    }
    newArgs[args.length] = sender;

    req.addArgs(newArgs);

    bytes32 assignedReqID = sendRequest(req, subscriptionId, gasLimit, tx.gasprice);
    latestRequestId = assignedReqID;
    return assignedReqID;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    // revert('test');
    latestResponse = response;
    latestError = err;
    emit OCRResponse(requestId, response, err);
  }

  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }
}

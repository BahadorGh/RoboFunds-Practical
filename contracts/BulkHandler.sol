// To handle many transactions we can implement like this:

/*
1- First get the length of the transactions list --> on-chain
2- Then provide an on-chain function to work on transactions list by chunking transactions in ranges.

3- After that, getting the length of transactions list with off-chain calling to our function in the 'First' part.
4- And then, calling the function which implementd in '2', several times untill the range ends.

*/

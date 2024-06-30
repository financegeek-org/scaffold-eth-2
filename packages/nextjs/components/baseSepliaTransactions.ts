import Web3 from 'web3';

// Type definitionsnpm install web3 @types/web3
type ContractABI = any[]; // Replace with a more specific type if available

interface ContractAddresses {
  USDC: string;
  TokenContract: string;
}

// Initialize Web3 and contracts
const initializeWeb3 = () => {
  const web3 = new Web3('https://base-sepolia.g.alchemy.com/v2/UqwRvCeB71FIweoaOAIoH2FYqJ6iottq'); 
  return web3;
};

const initializeContracts = (web3: Web3, addresses: ContractAddresses, abis: {USDC: ContractABI, TokenContract: ContractABI}) => {
  const usdcContract = new web3.eth.Contract(abis.USDC, addresses.USDC);
  const tokenContract = new web3.eth.Contract(abis.TokenContract, addresses.TokenContract);
  return { usdcContract, tokenContract };
};

// Function to approve USDC spending
export const approveUSDC = async (
  web3: Web3,
  usdcContract: any,
  spenderAddress: string,
  amount: string
): Promise<any> => {
  const accounts = await web3.eth.getAccounts();
  const fromAddress = accounts[0];

  try {
    const result = await usdcContract.methods.approve(spenderAddress, amount).send({
      from: fromAddress,
      gas: 200000 // Adjust gas as needed
    });
    console.log('USDC approval successful:', result.transactionHash);
    return result;
  } catch (error) {
    console.error('Error approving USDC:', error);
    throw error;
  }
};

// Function to buy tokens from your contract
export const buyToken = async (
  web3: Web3,
  yourContract: any,
  amount: string
): Promise<any> => {
  const accounts = await web3.eth.getAccounts();
  const fromAddress = accounts[0];

  try {
    const result = await yourContract.methods.buyToken(amount).send({
      from: fromAddress,
      gas: 300000 // Adjust gas as needed
    });
    console.log('Token purchase successful:', result.transactionHash);
    return result;
  } catch (error) {
    console.error('Error buying token:', error);
    throw error;
  }
};

// Export a function to initialize everything
export const initializeBaseSepoliaInteractions = (
  addresses: ContractAddresses,
  abis: {USDC: ContractABI, TokenContract: ContractABI}
) => {
  const web3 = initializeWeb3();
  const { usdcContract, tokenContract } = initializeContracts(web3, addresses, abis);

  return {
    approveUSDC: (spenderAddress: string, amount: string) => 
      approveUSDC(web3, usdcContract, spenderAddress, amount),
    buyToken: (amount: string) => buyToken(web3, tokenContract, amount),
  };
};
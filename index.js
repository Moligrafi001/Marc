async function CEP(cep) {
  try {
    const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error("Erro ao buscar CEP:", error);
    return false;
  };
};
async function CNPJ(cnpj) {
  try {
    const response = await fetch(`https://brasilapi.com.br/api/cnpj/v1/${cnpj}`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error("Erro ao buscar CNPJ:", error);
    return false;
  };
};
async function IP(ip) {
  try {
    const response = await fetch(`http://ipwho.is/${ip}`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error("Erro ao buscar IP:", error);
    return false;
  };
};

/*
IP("193.186.4.236").then(data => {
  console.log(data.city);
});
*/
IP("193.186.4.236").then(console.log);
// CEP(96090600);
// CNPJ(17005063000133);
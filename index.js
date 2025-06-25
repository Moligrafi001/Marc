async function CEP(cep) {
  try {
    const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error("Erro ao buscar CEP:", error);
  }
}
async function CNPJ(cnpj) {
  try {
    const response = await fetch(`https://brasilapi.com.br/api/cnpj/v1/${cnpj}`);
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error("Erro ao buscar CEP:", error);
  }
}
async function IP(ip) {
  try {
    const response = await fetch(`http://ipwho.is/${ip}`);
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error("Erro ao buscar CEP:", error);
  }
}

IP("")
// CEP(96090608);
// CNPJ(17005063000133);
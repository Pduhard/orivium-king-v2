import { task } from "hardhat/config";

task("orivium:addresses", "Retrieve deployed contract addresses").setAction(
  async (_, hre) => {
    Object.entries(await hre.deployments.all()).forEach(([k, v]) => {
      console.log(k, v.address);
      const entries = Object.entries(v);
      entries.forEach(([key, value]) => {
        console.log(key, value);
      });
    });
  }
);

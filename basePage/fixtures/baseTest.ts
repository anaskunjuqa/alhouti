import { test as baseTest, expect, TestInfo } from "@playwright/test";
import { CommonPage } from "../common/commonPage";
import { CommonScenario } from "../common/commonScenario";

interface PageObjects {
  commonPage: CommonPage;
  commonScenario: CommonScenario;
}

export const test = baseTest.extend<PageObjects>({
  commonScenario: async ({ page }, use, testInfo) => {
    const commonScenario = new CommonScenario(page, testInfo);
    await use(commonScenario);
  },
  commonPage: async ({ page, commonScenario }, use) => {
    const commonPage = new CommonPage(page, commonScenario);
    await use(commonPage);
  },

  
});

export { expect };

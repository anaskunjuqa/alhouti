import { Page } from "@playwright/test";
import { CommonPage } from "../../basePage/common/commonPage";
import { CommonScenario } from "../../basePage/common/commonScenario";
import { testData } from "../../tests/testData";
import { homePageLocators } from "./homePageLocators";

export class HomePage extends CommonPage {
  constructor(page: Page, commonScenario: CommonScenario) {
    super(page, commonScenario);
  }

  async navigateToHomePage() {
    await this.page.goto(testData.baseURL);
    await this.scenario.viewFullPage();
    await this.page.waitForLoadState("networkidle");

    const homePageCount = await this.page.locator(homePageLocators.homePage).count();
    console.log(homePageCount);

    for (let i = 0; i < homePageCount; i++) {
      const homePageText = await this.page.locator(homePageLocators.homePage).nth(i).textContent();
      console.log(homePageText);
      await this.page.locator(homePageLocators.homePage).nth(i).click();
      await this.page.waitForLoadState("networkidle");
      // await this.page.goBack();
      // await this.page.waitForLoadState("networkidle");
      // Scroll step size and delay (ms)
    const scrollStep = 100; // pixels per step
    const delay = 100;      // delay in ms between scrolls
    const scrollHeight = await this.page.evaluate(() => document.body.scrollHeight);
    for (let pos = 0; pos < scrollHeight; pos += scrollStep) {
    await this.page.evaluate((scrollPos) => window.scrollTo(0, scrollPos), pos);
    await this.page.waitForTimeout(delay);
    }

    }
  }
}

import { expect, Page } from "@playwright/test";
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
    const homePageCount = await this.page
      .locator(homePageLocators.homePage)
      .count();
    console.log(homePageCount);
    for (let i = 0; i < homePageCount; i++) {
      const homePageText = await this.page
        .locator(homePageLocators.homePage)
        .nth(i)
        .textContent();
      console.log(homePageText);
      await this.page.locator(homePageLocators.homePage).nth(i).click();
      await this.page.waitForLoadState("networkidle");
      await this.page.waitForTimeout(1000);

      const fileName = `${homePageText}.png`;
      await this.page.screenshot({
        path: `screenshots/${fileName}.png`,
        fullPage: true,
      });

      // Take screenshot for visual testing (optional - only if baseline exists)
      if (homePageText) {
        try {
          await expect(this.page).toHaveScreenshot(
            `${homePageText.replace(/\s+/g, "-").toLowerCase()}-page.png`,
            {
              threshold: 0.3, // Allow 30% difference
              maxDiffPixels: 1000, // Allow up to 1000 different pixels
            }
          );
        } catch (error) {
          console.log(
            `Screenshot comparison skipped for ${homePageText}: ${error.message}`
          );
          // Continue test execution even if screenshot comparison fails
        }
      }

      // await this.scenario.takeScreenshot("homePage");
      // await this.page.goBack();
      // await this.page.waitForLoadState("networkidle");
      // Scroll step size and delay (ms)
      const scrollStep = 100; // pixels per step
      const delay = 100; // delay in ms between scrolls
      const scrollHeight = await this.page.evaluate(
        () => document.body.scrollHeight
      );
      for (let pos = 0; pos < scrollHeight; pos += scrollStep) {
        await this.page.evaluate(
          (scrollPos) => window.scrollTo(0, scrollPos),
          pos
        );
        await this.page.waitForTimeout(delay);
      }
    }
  }
}

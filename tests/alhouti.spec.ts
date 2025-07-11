import { test, expect } from "../basePage/fixtures/baseTest";
import { HomePage } from "../pageObjects/HomePage/homePage";
import * as allure from "allure-js-commons";

test("e2e test", async ({ commonPage }) => {
  await allure.description("End-to-end test for Alhouti website navigation");
  await allure.owner("QA Team");
  await allure.tags("smoke", "e2e", "homepage");
  await allure.severity("critical");

  await allure.step(
    "Navigate to home page and verify basic functionality",
    async () => {
      const homePage = new HomePage(commonPage.page, commonPage.scenario);

      // Navigate to the website
      await commonPage.page.goto("https://alhouti.com");
      await commonPage.page.waitForLoadState("networkidle");

      // Verify page loaded successfully
      await expect(commonPage.page).toHaveTitle(/.*alhouti.*/i);

      // Take a screenshot for documentation
      await commonPage.page.screenshot({
        path: "screenshots/homepage-loaded.png",
        fullPage: true,
      });

      // Test navigation functionality (without screenshot comparison)
      await homePage.navigateToHomePage();
    }
  );
});

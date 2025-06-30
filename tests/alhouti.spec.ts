import { test } from "../basePage/fixtures/baseTest";
import { HomePage } from "../pageObjects/HomePage/homePage";

test("e2e test", async ({ commonPage }) => {
  const homePage = new HomePage(commonPage.page, commonPage.scenario);
  await homePage.navigateToHomePage();
});

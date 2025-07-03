import { test } from "../basePage/fixtures/baseTest";
import { HomePage } from "../pageObjects/HomePage/homePage";
import * as allure from "allure-js-commons";

test("e2e test", async ({ commonPage }) => {
  await allure.description("End-to-end test for Alhouti website navigation");
  await allure.owner("QA Team");
  await allure.tags("smoke", "e2e", "homepage");
  await allure.severity("critical");

  await allure.step("Navigate to home page", async () => {
    const homePage = new HomePage(commonPage.page, commonPage.scenario);
    await homePage.navigateToHomePage();
  });
});

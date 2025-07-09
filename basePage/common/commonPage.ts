import { Page } from "@playwright/test";
import { CommonScenario } from "./commonScenario";

export class CommonPage {
  constructor(public page: Page, readonly scenario: CommonScenario) {}

  async FullSize() {
    await this.scenario.viewFullPage();
  }
  async takeScreenshot() {
    await this.scenario.takeScreenshot();
  }
}

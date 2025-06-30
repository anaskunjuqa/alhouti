import { Page, TestInfo } from "@playwright/test";

export class CommonScenario {
  constructor(public page: Page, public testInfo: TestInfo) {}
  async viewFullPage() {
    await this.page.setViewportSize({ width: 1920, height: 1080 });
  }
}

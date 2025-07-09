import { Page, TestInfo } from "@playwright/test";
import fs from 'fs';


export class CommonScenario {
  constructor(public page: Page, public testInfo: TestInfo) {}
  async viewFullPage() {
    await this.page.setViewportSize({ width: 1920, height: 1080 });
  }
  async takeScreenshot(pageName: string) {
    const safeName = pageName.replace(/[/\\?%*:|"<>]/g, '-');
    // await this.page.screenshot({ path: `screenshots/${this.testInfo.title}.png`, fullPage: true });
    await this.page.screenshot({ path: `screenshots/${safeName}.png`, fullPage: true });
    if(!fs.existsSync('screenshots')){
      fs.mkdirSync('screenshots');
    }
    await this.page.waitForTimeout(1000);
  }
}

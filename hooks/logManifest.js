const fs = require('fs');
const path = require('path');
const et = require('elementtree');

module.exports = function (context) {
    const platforms = context.opts.platforms;

    if (!platforms.includes('android')) {
        return;
    }

    const projectRoot = context.opts.projectRoot;
    const manifestPath = path.join(
        projectRoot,
        'platforms',
        'android',
        'app',
        'src',
        'main',
        'AndroidManifest.xml'
    );

    if (!fs.existsSync(manifestPath)) {
        console.warn('[CustomDeeplinks] AndroidManifest.xml not found.');
        return;
    }

    const manifestContent = fs.readFileSync(manifestPath, 'utf8');
    const etreeManifest = et.parse(manifestContent);
    const manifestXml = etreeManifest.write({ indent: 4 });

    console.log('[CustomDeeplinks] AndroidManifest.xml:\n');
    console.log(manifestXml);
};

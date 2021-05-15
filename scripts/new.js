const Hexo = require('hexo');
const Inquirer = require('inquirer');

if (typeof process.env.FIRST === 'string' && process.env.FIRST.trim() === '1') {
    process.env.FIRST = null;

    const hexoInstance = new Hexo(process.cwd(), {});
    hexoInstance.init().then(async function() {
        let { title } = await Inquirer.prompt([{
            type: 'input',
            name: 'title',
            message: 'Input post\'s title: '
        }]);

        title = title.trim();
        if (!title.length) {
            console.error('No input title!');
            return;
        }

        await hexoInstance.post.create({ title });

        console.log('DONE');
        hexoInstance.exit();
    });
}

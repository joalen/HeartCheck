# What's New
- Switched to the Flutter frontend for a much pleasurable frontend experience and more features (plus it's still a relevant language)
- Switched from utilizing a local pkl file to an API endpoint that runs your prediction and auto-updates at will
 - prediction model now went from 77% accuracy to 95% accuracy ever since it switched to the H2O AutoML model
- Training is done on a GitHub Action runner that runs through an internal API call from a tool that watches for new data
- Cross-Platform support (thanks Flutter :D)
- Bug fixes
- Option to allow you to connect hospital data, provided it's either SQL, REST, GraphQL, XML SOAP (for now just these endpoints...more on the way)
- Added graph views of results for certain metrics
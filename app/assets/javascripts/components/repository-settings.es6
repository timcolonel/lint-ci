class RepositoriesSettings extends React.Component {
    static successDuration = 2000;
    loadCommentsFromServer() {
        this.state.user.repos.clone().fetchAll().then((repos) => {
            this.setState({repositories: repos})
        });
    }

    constructor(props) {
        super(props);
        this.state = {repositories: [], query: '', refreshing: false, success: false};
    }

    componentDidMount() {
        api.user().fetch().then((user) => {
            this.setState({user: user});
            this.loadCommentsFromServer();
            this.registerWebEvents();
        });
    }

    registerWebEvents() {
        this.channel = websocket.subscribe_private(this.state.user.channels.sync_repo);
        this.channel.bind('completed', () => {
            this.loadCommentsFromServer();
            this.setState({refreshing: false, success: true});
            setTimeout(() => {
                this.setState({success: false})
            }, RepositoriesSettings.successDuration);
            NotificationManager.success('Completed', 'Your repository were synced successfully');
        });
    }

    onSync(e) {
        e.preventDefault();
        Rest.post('/api/v1/user/repos/sync').done(() => {
            this.setState({refreshing: true, success: false})
        });
    }

    iconClasses() {
        if (this.state.success) {
            return 'fa fa-check'
        } else {
            return classNames({
                'fa fa-refresh': true,
                'fa-spin': this.state.refreshing
            });
        }
    }

    renderSyncBtn() {
        return (
            <a href='#' className='btn btn-default' onClick={this.onSync.bind(this)}>
                <i className={this.iconClasses()}/> Sync
            </a>
        )
    }

    render() {
        return (
            <div className="repositories-settings">
                <div className="box-title flex-center">
                    <h2 className='flex-fill'>Repositories</h2>
                    {this.renderSyncBtn()}
                </div>
                <RepositoryList repositories={this.state.repositories} readonly={false}/>
            </div>
        );
    }
}


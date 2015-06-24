class RepositoryComponent extends React.Component {
    constructor(props) {
        this.state = {
            repository: new Repository(api, props.repository)
        }
    }

    componentDidMount() {
        this.state.repository.fetch().then((repository) => {
            this.setState({repository: repository})
        });
    }

    refresh(e) {
        e.preventDefault();
        console.log(this);
        Rest.post(this.state.repository.refresh_url).done((repository) => {
            this.setState({repository: repository})
        });
    }

    render() {
        var repository = this.state.repository;
        var classes = classNames({
            'fa fa-refresh': true,
            'fa-spin': repository.refreshing
        });
        return (
            <div className="shadow-box">
                <div className="box-title flex-center">
                    <div className='repository-title flex-fill'>
                        {this.renderName()}
                        <a className='badge' href={repository.badges_url}><img
                            src={repository.badge_url}/></a>
                        <a className='badge' href={repository.badges_url}><img
                            src={repository.offense_badge_url}/></a>
                    </div>

                    <a href='#' onClick={this.refresh.bind(this)}>
                        <i className={classes}/>
                    </a>
                </div>

                <div>
                    <RevisionList repository={repository}/>
                </div>
            </div>
        )
    }

    renderName() {
        var repository = this.state.repository;
        return (
            <span>
                <a href={repository.owner.html_url}>{repository.owner.username}</a>
                     /{repository.name}
                </span>
        )
    }
}

component.Repository = RepositoryComponent;
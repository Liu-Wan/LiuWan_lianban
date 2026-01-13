window.addEventListener('message', function (event) {
    if (event.data.type === "OPEN_PANEL") {
        document.getElementById('app').style.display = 'flex';
        switchTab('search');
    } else if (event.data.type === "API_RESPONSE") {
        handleApiResponse(event.data.action, event.data.code, event.data.response);
    }
});

function closeUI() {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));

    document.getElementById('tab-' + tabId).classList.add('active');

    const icons = { 'search': 1, 'my_bans': 2, 'submit': 3 };
    if (icons[tabId] !== undefined) {
        const navIndex = icons[tabId] - 1;
        const items = document.querySelectorAll('.nav-item');
        if (items[navIndex]) items[navIndex].classList.add('active');
    }

    if (tabId === 'my_bans') {
        loadMyBans();
    }
}

function setLoading(isLoading, elementId = null) {
    if (elementId) {
        const btn = document.getElementById(elementId);
        if (btn) {
            if (isLoading) btn.classList.add('btn-loading');
            else btn.classList.remove('btn-loading');
            btn.disabled = isLoading;
        }
    } else {
        
    }
}

function performAction(action, data) {
    fetch(`https://${GetParentResourceName()}/performAction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            action: action,
            data: data
        })
    });
}

function handleApiResponse(action, code, responseJSON) {
    let response;
    if (typeof responseJSON === 'string') {
        try { response = JSON.parse(responseJSON); } catch (e) { response = responseJSON; }
    } else {
        response = responseJSON;
    }

    if (code !== 200) {
        showToast(response?.error || '请求失败 (Code: ' + code + ')', 'error');
    }

    if (action === 'searchBan') {
        setLoading(false, 'btn-search');
        renderSearchResult(response, code);
    } else if (action === 'myBans') {
        renderMyBans(response, code);
    } else if (action === 'submitBan') {
        setLoading(false, 'btn-submit-action');
        if (code === 200 && response.success) {
            showToast('提交成功！', 'success');
            document.getElementById('submit-identifier').value = '';
            document.getElementById('submit-reason').value = '';
            document.getElementById('submit-evidence').value = '';
            switchTab('my_bans');
        }
    } else if (action === 'removeBan') {
        if (code === 200 && response.success) {
            showToast('已解除封禁', 'success');
            loadMyBans();
        }
    } else if (action === 'requestUnban') {
        if (code === 200 && response.success) {
            showToast('解除申请已提交，等待管理员审核', 'success');
            loadMyBans();
        }
    }
}

function doSearch() {
    const id = document.getElementById('search-input').value.trim();
    if (!id) {
        showToast('请输入标识符', 'error');
        return;
    }
    setLoading(true, 'btn-search');
    document.getElementById('search-result').style.display = 'none';
    performAction('searchBan', { identifier: id });
}

function renderSearchResult(data, code) {
    const box = document.getElementById('search-result');
    box.style.display = 'block';

    if (code !== 200) return;

    if (data.banned) {
        box.innerHTML = `
            <div style="display:flex; align-items:center; gap:10px; margin-bottom:1rem;">
                <i class="fas fa-ban" style="font-size:1.5rem; color: #ef4444;"></i>
                <h3 style="margin:0; color: #ef4444;">此标识符已被封禁</h3>
            </div>
            <div class="result-row"><span class="label">标识符:</span> <span>${data.identifier || '未知'}</span></div>
            <div class="result-row"><span class="label">原因:</span> <span>${data.reason}</span></div>
            <div class="result-row"><span class="label">证据:</span> ${data.evidence ? '<a href="' + data.evidence + '" target="_blank" style="color: var(--primary);">查看证据</a>' : '无'}</div>
        `;
    } else {
        box.innerHTML = `
            <div style="display:flex; align-items:center; gap:10px;">
                <i class="fas fa-check-circle" style="font-size:1.5rem; color: #22c55e;"></i>
                <div>
                    <h3 style="margin:0; color: #22c55e;">未查到封禁记录</h3>
                    <div style="color: var(--text-muted); margin-top:4px;">该标识符在联盟数据库中信用良好。</div>
                </div>
            </div>
        `;
    }
}

function loadMyBans() {
    const tbody = document.getElementById('my-bans-list');
    tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: var(--text-muted);">加载中...</td></tr>';
    performAction('myBans', {});
}

function renderMyBans(list, code) {
    const tbody = document.getElementById('my-bans-list');
    tbody.innerHTML = '';

    if (code !== 200) {
        tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: var(--danger);">加载失败</td></tr>';
        return;
    }

    if (!list || list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: var(--text-muted);">暂无提交记录</td></tr>';
        return;
    }

    let rows = '';

    list.forEach(ban => {
        let status = '<span style="color: var(--warning);"><i class="fas fa-clock"></i> 审核中</span>';
        if (ban.status == 1) status = '<span style="color: var(--success);"><i class="fas fa-check"></i> 已生效</span>';
        if (ban.status == 2) status = '<span style="color: var(--danger);"><i class="fas fa-times"></i> 已驳回</span>';

        const escapedIdentifier = ban.identifier.replace(/'/g, "\\'");

        rows += `
            <tr>
                <td>${ban.identifier}</td>
                <td>${ban.reason}</td>
                <td>${status}</td>
                <td>
                    <button class="btn-sm btn-danger" onclick="doRemove(${ban.id}, '${escapedIdentifier}')">申请解除</button>
                </td>
            </tr>
        `;
    });

    tbody.innerHTML = rows;
}

function doSubmit() {
    const id = document.getElementById('submit-identifier').value.trim();
    const reason = document.getElementById('submit-reason').value.trim();
    const evidence = document.getElementById('submit-evidence').value.trim();

    if (!id || !reason) {
        showToast('请填写标识符和原因', 'error');
        return;
    }

    setLoading(true, 'btn-submit-action');
    performAction('submitBan', {
        identifier: id,
        reason: reason,
        evidence: evidence
    });
}

function doRemove(banId, identifier) {
    currentUnbanBanId = banId;
    document.getElementById('unban-identifier').textContent = identifier;
    document.getElementById('unban-reason').value = '';
    document.getElementById('unban-modal').classList.add('show');
}

let currentUnbanBanId = null;

function closeUnbanModal() {
    document.getElementById('unban-modal').classList.remove('show');
    currentUnbanBanId = null;
}

function submitUnbanRequest() {
    const reason = document.getElementById('unban-reason').value.trim();

    if (!reason) {
        showToast('请填写解除理由', 'error');
        return;
    }

    performAction('requestUnban', {
        ban_id: currentUnbanBanId,
        reason: reason
    });

    closeUnbanModal();
}

function showToast(msg, type = 'info') {
    const container = document.getElementById('toast-container');
    const el = document.createElement('div');
    el.className = `toast ${type}`;

    let icon = 'info-circle';
    if (type === 'success') icon = 'check-circle';
    if (type === 'error') icon = 'exclamation-triangle';

    el.innerHTML = `<i class="fas fa-${icon}"></i> <span>${msg}</span>`;

    container.appendChild(el);

    setTimeout(() => {
        el.style.animation = 'fadeOut 0.3s forwards';
        setTimeout(() => el.remove(), 300);
    }, 3000);
}

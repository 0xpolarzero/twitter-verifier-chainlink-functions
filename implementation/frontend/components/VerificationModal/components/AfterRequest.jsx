import { useEffect, useState } from 'react';
import {
  LoadingOutlined,
  ClockCircleOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  ExclamationCircleOutlined,
} from '@ant-design/icons';
import CostBreakdown from './CostBreakdown';
import { TwitterUsername, Address } from '../../Utils';
import { Divider } from 'antd';
import stores from '../../../stores';

const AfterRequest = ({ response, isRequesting }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const { replaceError } = stores.useVerification();

  useEffect(() => {
    if (isRequesting || response.data.result || response.error) {
      setIsExpanded(true);
    } else {
      setIsExpanded(false);
    }
  }, [isRequesting, response.data, response.error]);

  if (!isExpanded) return null;

  return (
    <div className='verification-after'>
      <Divider style={{ margin: 0 }} />
      <div className='header'>
        {isRequesting ? (
          <span className='status pending'>
            <ClockCircleOutlined />
            <span>Verification pending...</span>
          </span>
        ) : response.error ? (
          <span className='status failed'>
            <ExclamationCircleOutlined />
            <span>Error</span>
          </span>
        ) : Number(response.data.result) === 1 ? (
          <span className='status success'>
            <CheckCircleOutlined />
            Verification success
          </span>
        ) : (
          <span className='status failed'>
            <CloseCircleOutlined />
            Verification failed
          </span>
        )}
      </div>

      {isRequesting ? (
        <div className='content loading'>
          <LoadingOutlined />
        </div>
      ) : response.error ? (
        <div className='content' style={{ color: 'var(--color-yellow' }}>
          {response.errorMsg
            ? replaceError[response.errorMsg] ?? response.errorMsg
            : 'Something went wrong. Please try again.'}
        </div>
      ) : Number(response.data.result) === 1 ? (
        <div className='content'>
          <span>Twitter account</span>{' '}
          <TwitterUsername username={response.data.username} />{' '}
          <span>is now verified for</span>{' '}
          <Address address={response.data.address} />.
        </div>
      ) : (
        <div className='content'>
          <span>Twitter account</span>{' '}
          <TwitterUsername username={response.data.username} />{' '}
          <b>could not be verified</b> for{' '}
          <Address address={response.data.address} />.
        </div>
      )}

      {response.billing?.totalCost && !isRequesting && (
        <CostBreakdown billing={response.billing} />
      )}
    </div>
  );
};

export default AfterRequest;

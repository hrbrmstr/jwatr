package is.rud.wrc;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.LinkedList;
import java.util.List;
import java.io.InputStream;
import java.util.ArrayList;

import org.jwat.arc.ArcReader;
import org.jwat.arc.ArcReaderFactory;
import org.jwat.arc.ArcRecordBase;
import org.jwat.common.ByteCountingPushBackInputStream;
import org.jwat.common.ContentType;
import org.jwat.common.HttpHeader;
import org.jwat.common.Payload;
import org.jwat.common.RandomAccessFileInputStream;
import org.jwat.common.UriProfile;
import org.jwat.gzip.GzipEntry;
import org.jwat.gzip.GzipReader;
import org.jwat.tools.core.ValidatorPlugin;
import org.jwat.warc.WarcHeader;
import org.jwat.warc.WarcReader;
import org.jwat.warc.WarcReaderFactory;
import org.jwat.warc.WarcRecord;

public class App {

  public String[] contentLengthStr ;
  public String[] warcIdentifiedPayloadTypeStr ;
  public String[] warcProfileStr ;
  public String[] warcTargetUriStr ;
  public String[] warcRecordIdStr ;
  public String[] contentTypeStr ;
  public String[] warcTypeStr ;
  public String[] warcIpAddress ;
  public String[] warcDateStr ;
  public String[] httpStatusCode ;
  public String[] httpProtocolContentType ;
  public String[] httpVersion ;

  public List<byte[]> httpRawHeaders = null;
  public List<byte[]> warc_payload = null;

  public void process(String fil) {

    int n = 10000;

    List<String> tmp_contentLengthStr = new ArrayList<String>(n);
    List<String> tmp_warcIdentifiedPayloadTypeStr = new ArrayList<String>(n);
    List<String> tmp_warcProfileStr = new ArrayList<String>(n);
    List<String> tmp_warcTargetUriStr = new ArrayList<String>(n);
    List<String> tmp_warcRecordIdStr = new ArrayList<String>(n);
    List<String> tmp_contentTypeStr = new ArrayList<String>(n);
    List<String> tmp_warcTypeStr = new ArrayList<String>(n);
    List<String> tmp_warcIpAddress = new ArrayList<String>(n);
    List<String> tmp_warcDateStr = new ArrayList<String>(n);
    List<String> tmp_httpStatusCode = new ArrayList<String>(n);
    List<String> tmp_httpProtocolContentType = new ArrayList<String>(n);
    List<String> tmp_httpVersion = new ArrayList<String>(n);

    httpRawHeaders = new ArrayList<byte[]>(n);
    warc_payload = new ArrayList<byte[]>(n);

    UriProfile uriProfile = UriProfile.RFC3986;

    RandomAccessFile raf = null;
    RandomAccessFileInputStream rafin;

    ByteCountingPushBackInputStream pbin = null;

    GzipReader gzipReader = null;
    GzipEntry gzipEntry = null;

    WarcReader warcReader = null;
    WarcRecord warcRecord = null;

    try {

      File file = new File(fil);

      raf = new RandomAccessFile(file, "r");
      rafin = new RandomAccessFileInputStream(raf);
      pbin = new ByteCountingPushBackInputStream(new BufferedInputStream(rafin, 8192), 32);

      Payload payload = null;
      HttpHeader httpHeader = null;
      InputStream payloadStream = null;
      WarcHeader warc_header = null;

      if (GzipReader.isGzipped(pbin)) {

        gzipReader = new GzipReader(pbin);
        ByteCountingPushBackInputStream in;
        byte[] buffer = new byte[8192];

        while ((gzipEntry = gzipReader.getNextEntry()) != null) {

          in = new ByteCountingPushBackInputStream(new BufferedInputStream(gzipEntry.getInputStream(), 8192 ), 32);

            if (WarcReaderFactory.isWarcFile(in)) {

              warcReader = WarcReaderFactory.getReaderUncompressed();
              warcReader.setWarcTargetUriProfile(uriProfile);
              warcReader.setBlockDigestEnabled( true );
              warcReader.setPayloadDigestEnabled( true );

              while ((warcRecord = warcReader.getNextRecordFrom(in, gzipEntry.getStartOffset())) != null) {

                if (warcRecord.hasPayload()) {

                  httpHeader = warcRecord.getHttpHeader();
                  payload = warcRecord.getPayload();
                  warc_header = warcRecord.header ;

                  if (warc_header != null) {

                    tmp_contentLengthStr.add(warc_header.contentLengthStr);
                    tmp_warcIdentifiedPayloadTypeStr.add(warc_header.warcIdentifiedPayloadTypeStr);
                    tmp_warcProfileStr.add(warc_header.warcProfileStr);
                    tmp_warcTargetUriStr.add(warc_header.warcTargetUriStr);
                    tmp_warcRecordIdStr.add(warc_header.warcRecordIdStr);
                    tmp_contentTypeStr.add(warc_header.contentTypeStr);
                    tmp_warcTypeStr.add(warc_header.warcTypeStr);
                    tmp_warcIpAddress.add(warc_header.warcIpAddress);
                    tmp_warcDateStr.add(warc_header.warcDateStr);

                  } ;

                  byte[] payloadBytes = new byte[(int)payload.getRemaining()];
                  payload.getInputStream().read(payloadBytes);

                  warc_payload.add(payloadBytes);

                  if (httpHeader != null) {

                    tmp_httpStatusCode.add(httpHeader.getProtocolStatusCodeStr());
                    tmp_httpProtocolContentType.add(httpHeader.getProtocolContentType());
                    tmp_httpVersion.add(httpHeader.getProtocolVersion());
                    httpRawHeaders.add(httpHeader.getHeader());

                  } else {

                    tmp_httpStatusCode.add(null);
                    tmp_httpProtocolContentType.add(null);
                    tmp_httpVersion.add(null);
                    httpRawHeaders.add(new byte[0]);

                  }

                }

                warcRecord.close();

              }

            }

        }

      }

    } catch (Throwable t) {
      System.out.println("ERROR");
      System.out.println(t);
    }

    this.contentLengthStr = tmp_contentLengthStr.toArray(new String[tmp_contentLengthStr.size()]) ;
    this.warcIdentifiedPayloadTypeStr = tmp_warcIdentifiedPayloadTypeStr.toArray(new String[tmp_warcIdentifiedPayloadTypeStr.size()]) ;
    this.warcProfileStr = tmp_warcProfileStr.toArray(new String[tmp_warcProfileStr.size()]) ;
    this.warcTargetUriStr = tmp_warcTargetUriStr.toArray(new String[tmp_warcTargetUriStr.size()]) ;
    this.warcRecordIdStr = tmp_warcRecordIdStr.toArray(new String[tmp_warcRecordIdStr.size()]) ;
    this.contentTypeStr = tmp_contentTypeStr.toArray(new String[tmp_contentTypeStr.size()]) ;
    this.warcTypeStr = tmp_warcTypeStr.toArray(new String[tmp_warcTypeStr.size()]) ;
    this.warcIpAddress = tmp_warcIpAddress.toArray(new String[tmp_warcIpAddress.size()]) ;
    this.warcDateStr = tmp_warcDateStr.toArray(new String[tmp_warcDateStr.size()]) ;
    this.httpStatusCode = tmp_httpStatusCode.toArray(new String[tmp_httpStatusCode.size()]) ;
    this.httpProtocolContentType = tmp_httpProtocolContentType.toArray(new String[tmp_httpProtocolContentType.size()]) ;
    this.httpVersion = tmp_httpVersion.toArray(new String[tmp_httpVersion.size()]) ;

  }

}

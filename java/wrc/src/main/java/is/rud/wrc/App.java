package is.rud.wrc;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.LinkedList;
import java.util.List;
import java.io.InputStream;
import java.util.ArrayList;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.security.MessageDigest;
import java.util.Date;
import java.util.HashMap;

import org.jwat.common.ArrayUtils;
import org.jwat.common.ByteCountingPushBackInputStream;
import org.jwat.common.ContentType;
import org.jwat.common.DigestInputStreamNoSkip;
import org.jwat.common.HttpHeader;
import org.jwat.common.HttpHeader;
import org.jwat.common.Payload;
import org.jwat.common.Payload;
import org.jwat.common.PayloadWithHeaderAbstract;
import org.jwat.common.RandomAccessFileInputStream;
import org.jwat.common.RandomAccessFileOutputStream;
import org.jwat.tools.tasks.compress.RecordEntry;
import org.jwat.common.UriProfile;
import org.jwat.gzip.GzipConstants;
import org.jwat.gzip.GzipEntry;
import org.jwat.gzip.GzipReader;
import org.jwat.gzip.GzipWriter;
import org.jwat.tools.core.IOUtils;
import org.jwat.tools.core.ThreadLocalObjectPool;
import org.jwat.tools.core.ValidatorPlugin;
import org.jwat.warc.WarcHeader;
import org.jwat.warc.WarcReader;
import org.jwat.warc.WarcReaderFactory;
import org.jwat.warc.WarcRecord;

public class App {

	public String[] contentLengthStr;
	public String[] warcIdentifiedPayloadTypeStr;
	public String[] warcProfileStr;
	public String[] warcTargetUriStr;
	public String[] warcRecordIdStr;
	public String[] contentTypeStr;
	public String[] warcTypeStr;
	public String[] warcIpAddress;
	public String[] warcDateStr;
	public String[] httpStatusCode;
	public String[] httpProtocolContentType;
	public String[] httpVersion;

	public List < byte[] > httpRawHeaders = null;
	public List < byte[] > warc_payload = null;

	private static final int INPUT_BUFFER_SIZE = 16384;
	private static final int GZIP_OUTPUT_BUFFER_SIZE = 16384;
	private static final int BUFFER_SIZE = 8192;

	public void process(String fil) {

		int n = 10000;

		List < String > tmp_contentLengthStr = new ArrayList < String > (n);
		List < String > tmp_warcIdentifiedPayloadTypeStr = new ArrayList < String > (n);
		List < String > tmp_warcProfileStr = new ArrayList < String > (n);
		List < String > tmp_warcTargetUriStr = new ArrayList < String > (n);
		List < String > tmp_warcRecordIdStr = new ArrayList < String > (n);
		List < String > tmp_contentTypeStr = new ArrayList < String > (n);
		List < String > tmp_warcTypeStr = new ArrayList < String > (n);
		List < String > tmp_warcIpAddress = new ArrayList < String > (n);
		List < String > tmp_warcDateStr = new ArrayList < String > (n);
		List < String > tmp_httpStatusCode = new ArrayList < String > (n);
		List < String > tmp_httpProtocolContentType = new ArrayList < String > (n);
		List < String > tmp_httpVersion = new ArrayList < String > (n);

		httpRawHeaders = new ArrayList < byte[] > (n);
		warc_payload = new ArrayList < byte[] > (n);

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
				ByteCountingPushBackInputStream in ;
				byte[] buffer = new byte[8192];

				while ((gzipEntry = gzipReader.getNextEntry()) != null) {

					in =new ByteCountingPushBackInputStream(new BufferedInputStream(gzipEntry.getInputStream(), 8192), 32);

					if (WarcReaderFactory.isWarcFile( in )) {

						warcReader = WarcReaderFactory.getReaderUncompressed();
						warcReader.setWarcTargetUriProfile(uriProfile);
						warcReader.setBlockDigestEnabled(true);
						warcReader.setPayloadDigestEnabled(true);

						while ((warcRecord = warcReader.getNextRecordFrom( in , gzipEntry.getStartOffset())) != null) {

							if (warcRecord.hasPayload()) {

								httpHeader = warcRecord.getHttpHeader();
								payload = warcRecord.getPayload();
								warc_header = warcRecord.header;

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

								};

								byte[] payloadBytes = new byte[(int) payload.getRemaining()];
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

			} else {

				if (WarcReaderFactory.isWarcFile(pbin)) {

					warcReader = WarcReaderFactory.getReader(pbin);
					warcReader.setWarcTargetUriProfile(uriProfile);
					warcReader.setBlockDigestEnabled(true);
					warcReader.setPayloadDigestEnabled(true);

					while ((warcRecord = warcReader.getNextRecord()) != null) {

						if (warcRecord.hasPayload()) {

							httpHeader = warcRecord.getHttpHeader();
							payload = warcRecord.getPayload();
							warc_header = warcRecord.header;

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

							};

							byte[] payloadBytes = new byte[(int) payload.getRemaining()];
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

		} catch(Throwable t) {
			System.out.println("ERROR");
			System.out.println(t);
		}

		this.contentLengthStr = tmp_contentLengthStr.toArray(new String[tmp_contentLengthStr.size()]);
		this.warcIdentifiedPayloadTypeStr = tmp_warcIdentifiedPayloadTypeStr.toArray(new String[tmp_warcIdentifiedPayloadTypeStr.size()]);
		this.warcProfileStr = tmp_warcProfileStr.toArray(new String[tmp_warcProfileStr.size()]);
		this.warcTargetUriStr = tmp_warcTargetUriStr.toArray(new String[tmp_warcTargetUriStr.size()]);
		this.warcRecordIdStr = tmp_warcRecordIdStr.toArray(new String[tmp_warcRecordIdStr.size()]);
		this.contentTypeStr = tmp_contentTypeStr.toArray(new String[tmp_contentTypeStr.size()]);
		this.warcTypeStr = tmp_warcTypeStr.toArray(new String[tmp_warcTypeStr.size()]);
		this.warcIpAddress = tmp_warcIpAddress.toArray(new String[tmp_warcIpAddress.size()]);
		this.warcDateStr = tmp_warcDateStr.toArray(new String[tmp_warcDateStr.size()]);
		this.httpStatusCode = tmp_httpStatusCode.toArray(new String[tmp_httpStatusCode.size()]);
		this.httpProtocolContentType = tmp_httpProtocolContentType.toArray(new String[tmp_httpProtocolContentType.size()]);
		this.httpVersion = tmp_httpVersion.toArray(new String[tmp_httpVersion.size()]);

	}

	public static void compressWarcFile(String srcFname, String dstFname) {

		File srcFile = new File(srcFname);
		File dstFile = new File(dstFname);
		RandomAccessFile raf = null;
		RandomAccessFileInputStream rafin = null;
		InputStream in =null;
		byte[] buffer = new byte[BUFFER_SIZE];
		InputStream uncompressedFileIn = null;
		RandomAccessFile rafOut = null;
		OutputStream out = null;
		GzipWriter writer = null;
		GzipEntry entry = null;
		WarcReader warcReader = null;
		WarcRecord warcRecord = null;
		OutputStream cout = null;
		Payload payload;
		int read;
		InputStream pin = null;
		MessageDigest md5uncomp = null;
		MessageDigest md5comp = null;
		InputStream compressedFileIn = null;
		GzipReader reader = null;
		InputStream uncompressedEntryIn = null;
		RecordEntry recordEntry = null;

		try {
			raf = new RandomAccessFile(srcFile, "r");
			rafin = new RandomAccessFileInputStream(raf);
			in =new ByteCountingPushBackInputStream(new BufferedInputStream(rafin, INPUT_BUFFER_SIZE), 32);
			rafOut = new RandomAccessFile(dstFile, "rw");
			out = new RandomAccessFileOutputStream(rafOut);
			writer = new GzipWriter(out, GZIP_OUTPUT_BUFFER_SIZE);
			writer.setCompressionLevel(java.util.zip.Deflater.DEFAULT_COMPRESSION);

			uncompressedFileIn = in;

			warcReader = WarcReaderFactory.getReader(uncompressedFileIn);
			warcReader.setBlockDigestEnabled(true);
			warcReader.setPayloadDigestEnabled(true);
			long readerConsumed = warcReader.getConsumed();
			while ((warcRecord = warcReader.getNextRecord()) != null) {
				Date date = warcRecord.header.warcDate;
				if (date == null) {
					date = new Date();
				}
				entry = new GzipEntry();
				entry.magic = GzipConstants.GZIP_MAGIC;
				entry.cm = GzipConstants.CM_DEFLATE;
				entry.flg = 0;
				entry.mtime = date.getTime() / 1000;
				entry.xfl = 0;
				entry.os = GzipConstants.OS_UNKNOWN;
				writer.writeEntryHeader(entry);

				cout = entry.getOutputStream();

				payload = warcRecord.getPayload();
				if (payload != null) {
					// Payload
					pin = payload.getInputStreamComplete();
					pin.close();
					pin = null;
					payload.close();
				}
				warcRecord.close();
				long offset = warcRecord.getStartOffset();
				long consumed = warcRecord.getConsumed();
				warcRecord = null;
				long oldPos = raf.getFilePointer();
				raf.seek(offset);
				while (consumed > 0) {
					read = (int) Math.min(consumed, (long) buffer.length);
					read = raf.read(buffer, 0, read);
					if (read > 0) {
						consumed -= read;
						cout.write(buffer, 0, read);
					}
				}
				raf.seek(oldPos);

				cout.close();
				cout = null;
				entry.close();
				entry = null;
				readerConsumed = warcReader.getConsumed();

			}

			if (readerConsumed < raf.length()) {

				entry = new GzipEntry();
				entry.magic = GzipConstants.GZIP_MAGIC;
				entry.cm = GzipConstants.CM_DEFLATE;
				entry.flg = 0;
				entry.mtime = new Date().getTime() / 1000;
				entry.xfl = 0;
				entry.os = GzipConstants.OS_UNKNOWN;
				writer.writeEntryHeader(entry);
				cout = entry.getOutputStream();
				raf.seek(readerConsumed);
				while ((read = raf.read(buffer)) != -1) {
					cout.write(buffer, 0, read);
				}
				cout.close();
				cout = null;
				entry.close();
				entry = null;

			}

			writer.close();
			writer = null;
			out.close();
			out = null;
			rafOut.close();
			rafOut = null;
			warcReader.close();
			warcReader = null;
			uncompressedFileIn.close();
			uncompressedFileIn = null;
			in .close();
			in =null;

		} catch(Throwable t) {
			t.printStackTrace();
		} finally {
			IOUtils.closeIOQuietly(pin);
			IOUtils.closeIOQuietly(warcRecord);
			IOUtils.closeIOQuietly(warcReader);
			IOUtils.closeIOQuietly(uncompressedFileIn);
			IOUtils.closeIOQuietly( in );
			IOUtils.closeIOQuietly(cout);
			IOUtils.closeIOQuietly(writer);
			IOUtils.closeIOQuietly(out);
			IOUtils.closeIOQuietly(rafOut);
			IOUtils.closeIOQuietly(uncompressedEntryIn);
			IOUtils.closeIOQuietly(entry);
			IOUtils.closeIOQuietly(reader);
			IOUtils.closeIOQuietly(compressedFileIn);
		}

	}

}